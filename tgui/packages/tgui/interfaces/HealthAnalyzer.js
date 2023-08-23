import { Window } from '../layouts';
import {
  Box,
  Section,
  ProgressBar,
  LabeledList,
  Icon
} from '../components';
import { round } from 'common/math';
import { useBackend } from '../backend'

const stats = [
  'Alive',
  'Critical',
  'DEAD'
]

export const HealthAnalyzer = (props, context) => {
  const { data } = useBackend(context);
  const {
    name,
    stat,
    dnr,
    health,
    maxHealth,
    dmgBrute,
    dmgBurn,
    dmgToxin,
    dmgOxy,
    bloodData = {}
  } = data;

  return (
    <Window resizable>
      <Window.Content>
        <Section title={"Vital Signs"}>
          <LabeledList>
            <LabeledList.Item label="Name">
              {name}
            </LabeledList.Item>
            <LabeledList.Item label="Health">
              {health >= 0 ? (
                <ProgressBar
                  value={health / maxHealth}
                  ranges={{
                    good: [0.7, Infinity],
                    average: [0.2, 0.7],
                    bad: [-Infinity, 0.2],
                  }}>
                  {round(health, 1)}%</ProgressBar>
              ) : (
                <ProgressBar
                  value={1 + health / maxHealth}
                  ranges={{
                    bad: [-Infinity, Infinity],
                  }}>
                  {round(health, 1)}%</ProgressBar>     // Health text used so it shows negative while bar is full
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Damage">
              <Box inline mr="5px">
                <ProgressBar>
                  Brute:{' '}
                  <Box inline bold color={'red'}>
                    {round(dmgBrute, 1)}
                  </Box>
                </ProgressBar>
              </Box>
              <Box inline mr="5px">
                <ProgressBar>
                  Burn:{' '}
                  <Box inline bold color={'#ffb833'}>
                    {round(dmgBurn, 1)}
                  </Box>
                </ProgressBar>
              </Box>
              <Box inline mr="5px">
                <ProgressBar>
                  Toxin:{' '}
                  <Box inline bold color={'green'}>
                    {round(dmgToxin, 1)}
                  </Box>
                </ProgressBar>
              </Box>
              <Box inline>
                <ProgressBar>
                  Suffocation:{' '}
                  <Box inline bold color={'blue'}>
                    {round(dmgOxy, 1)}
                  </Box>
                </ProgressBar>
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label={'Blood ' + (bloodData.bloodType ?? '')}>
              {bloodData.hasBlood ?
                <Box color={bloodData.bloodStatusColor}>
                  {bloodData.percent}%, {bloodData.volume}cl{bloodData.bloodWarningMessage}
                </Box>
                :
                'No bloodstream detected in patient.'}
            </LabeledList.Item>
          </LabeledList>
        </Section>

        <Section title="Status">
          <Box>They seem to be {stats[stat]}.</Box>
        </Section>
      </Window.Content>
    </Window>
  );
};
